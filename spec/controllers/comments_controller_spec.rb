require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  describe "GET #index" do
    let(:comment) { create :comment }
    
    before(:each) do
      get :index, params: {}
    end

    it "should have http status :ok" do
      expect(response).to have_http_status(:ok)
    end

    it 'should render all comments' do
      expected = ActiveModelSerializers::SerializableResource::new(
        Comment.all,
        each_serializer: CommentSerializer
      ).to_json
      expect(response.body).to eq(expected)
    end
  end

  describe "GET #show" do
    let(:comment) { create :comment }
    before do
      get :show, params: { id: comment.id }
    end

    it "should have http status :ok" do
      expect(response).to have_http_status(:ok)
    end

    it 'should contains all comment fields' do
      comment_json = JSON.parse(response.body)
      expect(comment_json['id']).to eq(comment.id)
      expect(comment_json['content']).to eq(comment.content)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      let(:expected_post) { create :post , :with_image }
      let(:expected_comment) { build :comment, post_id: expected_post.id }
      let(:attrs_comment) { attributes_for :comment, post_id: expected_post.id }
      before do
        post :create, params: { 
          content: expected_comment.content, 
          post_id: expected_comment.post_id
        }
      end

      it 'should have http status created' do
        expect(response).to have_http_status(:created)
      end

      it "should creates a new Comment" do
        comment_json = JSON.parse(response.body)
        expect(comment_json['content']).to eq(expected_comment.content)
        expect(comment_json['post']['_id']).to eq(expected_comment.post_id)
      end

      it "should increment the count by 1" do
        expect{ 
          post :create, params: attrs_comment
        }.to change { Comment.count }.by(1)
      end
    end

    context "with invalid params" do
      let(:expected_comment) { build :comment, post_id: -1 }

      before do
        post :create, params: { 
          content: expected_comment.content, 
          post_id: expected_comment.post_id
        }
      end

      it "should response with errors for the new comment" do
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end

      it 'should have message post must exist' do
        expect(response.body).to include("must exist")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:comment) { create :comment }
      let(:other_comment) { build :comment, :other_comment }
      let(:attrs_comment) { attributes_for :comment, id: comment.id }

      context 'when comment is successfully update' do
        before do
          put :update, params: { 
            id: comment.id, 
            content: other_comment.content,              
          }
        end

        it 'should have http status :ok' do
          expect(response).to have_http_status(:ok)
        end

        it 'should have different fields' do
          body = JSON.parse(response.body)
          content = body['content']
          post_id = body['post_id']
          expect(content).not_to eq(comment.content)
          expect(post_id).not_to eq(comment.post_id)
        end

        it "should not increment the count by 1" do
          expect{ 
            put :update, params: attrs_comment
          }.to change { Comment.count }.by(0)
        end
      end

      context 'when comment wasn\'t updated' do
        context 'when comment wasn\'t found' do
          before do
            put :update, params: { id: -1 }
          end
          it 'responds :not_found' do
            expect(response).to have_http_status(:not_found)
          end
          it 'contains not_found message' do
            expect(response.body).to include("not found")
          end
        end

        context 'when post wasn\'t exist' do
          before do
            put :update, params: { 
              id: comment.id, 
              content: other_comment.content,  
              post_id: -1            
            }
          end

          it 'should have message post must exist' do
            expect(response.body).to include("must exist")
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:comment) { create :comment }
    context 'when comment exists' do
      before do
        delete :destroy, params: { id: comment.id }
      end
      
      it 'should have http status :no_content' do
        expect(response).to have_http_status(:no_content)
      end

      it 'should not find the comment' do
        expect(Comment.find_by_id(comment.id)).to be_nil
      end
    end

    context 'when comment does not exist' do
      before do
        delete :destroy, params: { id: -1 }
      end

      it 'should responds with :not_found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'should contains not_found message' do
        expect(response.body).to include("not found")
      end
    end
  end
end
