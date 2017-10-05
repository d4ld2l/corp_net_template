require 'spec_helper'

RSpec.describe 'API::V0::Resources' do
  subject(:user) { create :user }
  before { @cred = auth user }

  EXCLUDED_CONTROLLERS = [Api::V0::Resources::NewsController]

  (Api::ResourceController.subclasses - EXCLUDED_CONTROLLERS).each do |c|
    describe c, type: :controller do
      describe c.name.demodulize do
        let(:resource) { create c.to_s.demodulize.underscore.remove('_controller').singularize.to_sym }
        after(:each) { expect(response).to have_http_status :success }

        it { post :create, params: { c.to_s.demodulize.underscore.remove('_controller').singularize.to_sym => { name: 'first' } }.merge(@cred) }

        it { get :index, params: @cred, format: :json }

        it { get :show, params: { id: resource.id }.merge(@cred), format: :json }

        it { patch :update, params: { id: resource.id, c.to_s.demodulize.underscore.remove('_controller').singularize.to_sym => { name: 'second' } }.merge(@cred) }

        it { delete :destroy, params: { id: resource.id }.merge(@cred) }
      end
    end
  end
end
