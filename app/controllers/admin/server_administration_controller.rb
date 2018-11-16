class Admin::ServerAdministrationController < ApplicationController
  def index

  end

  def reindex
    ElasticReindexerWorker.perform_async
    redirect_to server_administration_path, notice: 'Запущена задача переиндексирования ElasticSearch'
  end
end
