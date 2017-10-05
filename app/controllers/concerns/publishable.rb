module Publishable
  extend ActiveSupport::Concern

  included do
    before_action :set_resource, only: [:edit, :update, :show, :destroy, :publish, :unpublish, :archive, :repair]
  end

  def publish
    change_state('published', "Успешно опубликовано!")
  end

  def unpublish
    change_state('unpublished', "Успешно переведено в статус 'Не опубликовано'!")
  end

  def archive
    change_state('archived', "Успешно перенесено в архив!")
  end

  def repair
    change_state('draft', "Успешно перенесено в черновики!")
  end

  def change_state(to_state, text)
    @resource_instance.send("to_#{to_state}") if @resource_instance.send("may_to_#{to_state}?")
    @resource_instance.save
    respond_with @resource_instance do |format|
      format.html { redirect_to @resource_instance, notice: text }
    end
  end
end
