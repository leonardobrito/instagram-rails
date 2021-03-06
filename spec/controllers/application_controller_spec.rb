require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'GET #index' do
    context 'when application is up' do
      before do
        get :index
      end

      it 'should have http status ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'should show status message' do
        @expected = { 
          status: "It's work!"
        }.to_json
        expect(response.body).to eq(@expected)
      end
    end
  end
end
