class Api::V0::Resources::DiscussionsController < Api::ResourceController
  include Likable
  include Discussion::Favoritable

  before_action :set_resource, only: %i[show update destroy mark_as_read mark_all_as_read close open like unlike likes to_favorites from_favorites add_discussers remove_discussers join leave]

  def index
    render json: { discussions: @collection.as_json(inclusion),
                   available_count: resource_collection.available(current_account.id).count,
                   active_count: resource_collection.active(current_account.id).count,
                   favorites_count: resource_collection.favorites(current_account.id).count,
                   search_count: @search_count }
  end

  def filters
    result = if %w[available active favorites].include? params[:scope]
               resource_collection.send(params[:scope], current_account.id)
             else
               resource_collection.active(current_account.id)
             end
    render json: { authors: result.authors.as_json(only: :id, methods: :full_name),
                   categories: result.categories.as_json }
  end

  def counters
    render json: {
      available_count: resource_collection.available(current_account.id).count,
      active_count: resource_collection.active(current_account.id).count,
      favorites_count: resource_collection.favorites(current_account.id).count
    }
  end

  def show
    render json: @resource_instance.as_json(inclusion)
  end

  def create
    @resource_instance.author_id = current_account.id
    if @resource_instance.save
      render json: @resource_instance.as_json(inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def update
    if @resource_instance.update(resource_params)
      render json: @resource_instance.as_json(inclusion)
    else
      render json: { success: false, errors: @resource_instance.errors }
    end
  end

  def destroy
    ActiveRecord::Base.transaction do
      @several_resource.each(&:destroy)
    end
    render json: { success: true, available_count: resource_collection.available(current_account.id).count,
                   active_count: resource_collection.active(current_account.id).count,
                   favorites_count: resource_collection.favorites(current_account.id).count }
  rescue StandardError => e
    render json: { success: false, errors: e.message }
  end

  def mark_as_read
    @resource_instance.read!(current_account.id, params[:read_at])
    render json: { success: true, unread_count: @resource_instance.as_json(current_account_id: current_account.id)['unread_count'] }
  end

  def mark_all_as_read
    @resource_instance.read_all!(current_account.id)
  end

  def close
    ActiveRecord::Base.transaction do
      @several_resource.map(&:close!)
    end
    render json: { success: true }
  rescue ClosingClosedDiscussion => e
    render json: { success: false, errors: e.message }
  end

  def open
    ActiveRecord::Base.transaction do
      @several_resource.map(&:open!)
    end
    render json: { success: true }
  rescue OpeningOpenedDiscussion => e
    render json: { success: false, errors: e.message }
  end

  def add_discussers
    @resource_instance.add_discussers!(params[:account_ids])
    @resource_instance.reload
    render json: @resource_instance.as_json(inclusion)
  rescue StandardError => e
    render json: { success: false, error: e.message }
  end

  def remove_discussers
    @resource_instance.remove_discussers!(params[:account_ids])
    @resource_instance.reload
    render json: @resource_instance.as_json(inclusion)
  rescue StandardError => e
    render json: { success: false, error: e.message }
  end

  def join
    @resource_instance.join!(current_account.id)
    @resource_instance.reload
    render json: @resource_instance.as_json(inclusion)
  rescue StandardError => e
    render json: { success: false, error: e.message }
  end

  def leave
    @resource_instance.leave!(current_account.id)
    @resource_instance.reload
    render json: @resource_instance.as_json(inclusion)
  rescue StandardError => e
    render json: { success: false, error: e.message }
  end

  def permitted_attributes
    [:id, :name, :body, :available_to_all, :logo,
     discussers_attributes: %i[id account_id _destroy],
     photos_attributes: %i[id name file _destroy],
     documents_attributes: %i[id name file _destroy]]
  end

  def build_resource
    @resource_instance ||= resource_collection.new(action_name == 'create' ? resource_params : {})
    instance_variable_set("@#{resource_name}", @resource_instance)
  end

  def resource_collection
    if %w[surveys tasks bids vacancies events projects mailing_lists].include? params[:entity_type]
      @resource_collection ||= params[:entity_type].singularize.classify.constantize.find(params[:entity_id]).discussions
    else
      @resource_collection ||= resource_name.classify.constantize
    end
  end

  def association_chain
    result = resource_collection.includes(chain_collection_inclusion)
    result = if %w[available active favorites].include? params[:scope]
               result.send(params[:scope], current_account.id)
             else
               result.active(current_account.id)
             end
    result = result.unread(current_account.id) if params.fetch(:unread, nil) == '1'
    result.order(last_comment_at: :desc).page(page).per(per_page)
  end

  def search
    result = Discussion.search(params[:q], params.to_unsafe_h)
    total = result.results.total
    result = result.page(1).per(total).records.all.includes(chain_collection_inclusion)
    if %w[surveys tasks bids vacancies events projects mailing_lists].include? params[:entity_type]
      result = result.where(discussable_type: params[:entity_type].singularize.classify, discussable_id: params[:entity_id])
    end
    result = if %w[available active favorites].include? params[:scope]
               result.send(params[:scope], current_account.id)
             else
               result.active(current_account.id)
             end
    result = result.unread(current_account.id) if params.fetch(:unread, nil) == '1'
    @search_count = result.count
    result.page(page).per(per_page)
  end

  def set_resource
    if params[:select]
      @several_resource ||= resource_collection.includes(chain_resource_inclusion).find(params[:select].split(','))
    elsif params[:id]
      @resource_instance ||= resource_collection.includes(chain_resource_inclusion).find(params[:id])
    end
    raise ActiveRecord::RecordNotFound, params[:path] unless @resource_instance.present? || params[:select]
  end

  def set_collection
    @collection ||= (params.keys.map(&:to_s) & %w[q author_id discussable_visibility type created_at state]).any? ? search : association_chain
    instance_variable_set("@#{collection_name}", @collection)
  end

  private

  def inclusion
    @inclusion ||= {
      include: {
        author: {
          methods: [:full_name]
        },
        photos: {},
        documents: {},
        discussers: { include: { account: { methods: :full_name } } }
      },
      except: [:comments_count],
      current_account_id: current_account.id
    }
  end

  def json_resource_inclusion
    @json_resource_inclusion ||= {
      include: {
        author: {
          methods: [:full_name]
        },
        photos: {},
        documents: {},
        discussers: { include: { account: { methods: :full_name } } }
      },
      except: [:comments_count],
      current_account_id: current_account.id
    }
  end

  def json_collection_inclusion
    @json_collection_inclusion ||= {
      include: {
        author: {
          methods: [:full_name]
        }
      },
      except: [:comments_count],
      current_account_id: current_account.id
    }
  end

  def chain_collection_inclusion
    @chain_collection_inclusion ||= [:author]
  end

  def chain_resource_inclusion
    @chain_resource_inclusion ||= [:photos, :documents, :author, discussers: :account]
  end
end
