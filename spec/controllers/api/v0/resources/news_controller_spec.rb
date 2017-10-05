require 'rails_helper'

RSpec.describe Api::V0::Resources::NewsController, type: :controller do
  subject(:user) { create :user }
  before(:each) { @cred = auth user }

  describe 'watch record' do
    before(:each) do
      @resource = create :news_item
      5.times { @resource.news_groups += [create(:news_group)] }
      @resource.news_category = create :news_category
    end

    context '#index' do
      it 'record' do
        get :index, params: @cred
        expect(JSON.parse(response.body).count).to eq(@resource.class.count)
      end

      it 'nested record' do
        get :index, params: @cred
        expect(JSON.parse(response.body).first['news_groups'].count).to eq(@resource.news_groups.count)
      end
    end

    context '#show' do
      it 'record' do
        get :show, params: { id: @resource.id }.merge(@cred)
        expect(JSON.parse(response.body)['id']).to eq(@resource.id)
      end

      it 'nested record' do
        get :show, params: { id: @resource.id }.merge(@cred)
        expect(JSON.parse(response.body)['news_groups'].first['id']).to eq(@resource.news_groups.first.id)
      end
    end

    context '#update' do
      it 'record' do
        patch :update, params: { id: @resource.id, news_item: { title: 'second' } }.merge(@cred)
        expect(JSON.parse(response.body)['title']).to eq('second')
      end

    end

    context '#destroy' do
      it 'record' do
        count = @resource.class.count
        delete :destroy, params: { id: @resource.id }.merge(@cred)
        expect(count).not_to eq(@resource.class.count)
      end
    end

    context '#states' do
      it 'it is a Array' do
        get :states, params: { id: @resource.id }.merge(@cred)
        expect(JSON.parse(response.body)).to be_a_kind_of(Array)
      end

      it 'count all states' do
        get :states, params: { id: @resource.id }.merge(@cred)
        expect(JSON.parse(response.body).count).to eq(4)
      end
    end

    context '#allowed_states' do
      it 'it is a Array' do
        get :allowed_states, params: { id: @resource.id }.merge(@cred)
        expect(JSON.parse(response.body)).to be_a_kind_of(Array)
      end

      it 'new is allowed' do
        get :allowed_states, params: { id: @resource.id }.merge(@cred)
        expect(JSON.parse(response.body).first).to eq('published')
      end
    end

    context '#change_state' do
      it 'have status success?' do
        patch :change_state, params: { id: @resource.id, state: :published }.merge(@cred)
        expect(response).to have_http_status :success
      end

      it 'state of news_item is published?' do
        patch :change_state, params: { id: @resource.id, state: :published }.merge(@cred)
        expect(JSON.parse(response.body)['news_item']['state']).to eq('published')
      end
    end
  end
end
