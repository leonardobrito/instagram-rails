require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  describe 'GET #index' do
    let(:post) { create :post, :with_image }
    before(:each) do
      get :index
    end

    it 'should have http status ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'should render all posts' do
      expected = ActiveModelSerializers::SerializableResource::new(
        Post.all,
        each_serializer: PostSerializer
      ).to_json
      expect(response.body).to eq(expected)
    end
  end

  describe 'GET #show' do
    context 'when post exists' do
      let(:post) { create :post, :with_image }
      let(:image_name) { 'box-juice.png' }
      before do
        get :show, params: { id: post.id }
      end

      it 'should have http status :ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'should contains all post fields' do
        post_json = JSON.parse(response.body)
        expect(post_json['_id']).to eq(post.id)
        expect(post_json['author']).to eq(post.author)
        expect(post_json['place']).to eq(post.place)
        expect(post_json['description']).to eq(post.description)
        expect(post_json['hashtags']).to eq(post.hashtags)
        body_image_name = post_json['image'].split('/').last
        expect(body_image_name).to eq(image_name)
      end
    end

    context 'when post does not exist' do
      before do
        get :show, params: { id: -1 }
      end

      it 'should responds with :not_found' do
        expect(response).to have_http_status(:not_found)
      end

      it 'should contains not_found message' do
        expect(response.body).to include("not found")
      end
    end
  end

  describe 'POST #create' do
    let(:image_name) { 'box-juice.png' }
    let(:file_path) { Rails.root.join('spec', 'support', 'assets', image_name) }
    let(:file) { fixture_file_upload(file_path, 'image/png') }

    context 'when post is created' do
      let(:attrs_post) { attributes_for :post, image: file }
      let(:expected_post) { attributes_for :post, image: file }
      before do
        post :create, params: expected_post
      end

      it 'should have http status :created' do
        expect(response).to have_http_status(:created)
      end

      it 'should have expected post fields' do
        expected = expected_post.as_json
        post_json = JSON.parse(response.body)
        expect(post_json['author']).to eq(expected['author'])
        expect(post_json['place']).to eq(expected['place'])
        expect(post_json['description']).to eq(expected['description'])
        expect(post_json['hashtags']).to eq(expected['hashtags'])
      end

      it 'should contains the image_name on image' do
        body_image_name = JSON(response.body)['image'].split('/').last
        expect(body_image_name).to eq(image_name)
      end

      it "should increment the count by 1" do
        expect{
          post :create, params: attrs_post
        }.to change { Post.count }.by(1)
      end
    end

    context 'when post is not create' do
      context 'when author is empty' do
        before do
          post :create, params: {}
        end

        it 'should have http status :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should contains author can\'t be blank message' do
          body = response.body
          author_errors = JSON(body)['errors']['author']
          expect(author_errors).to include("can't be blank")
        end
      end
    end

    context 'when author already has been taken' do
      let(:expected_post) { create :post, :with_image }
      before do
        post :create, params: {
          author: expected_post.author,
          place: expected_post.place,
          description: expected_post.description,
          hashtags: expected_post.hashtags,
          image: file
        }
      end

      it 'should have http status :unprocessable_entity' do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'should contains author has already been taken message' do
        body = response.body
        author_errors = JSON(body)['errors']['author']
        expect(author_errors).to include('has already been taken')
      end
    end
  end

  describe 'PUT #update' do
    let(:post) { create :post, :with_image }
    let(:other_post) { build :post }
    let!(:third_post) { create :post }
    let(:other_image_name) { 'other-box-juice.png' }
    let(:file_path) { Rails.root.join('spec', 'support', 'assets', other_image_name) }
    let(:other_file) { fixture_file_upload(file_path, 'image/png') }
    let(:attrs_post) { attributes_for :post, id: post.id, image: other_file }
    let(:third_file) { fixture_file_upload(file_path, 'image/png') }

    context 'when post is successfully updated' do
      before do
        put :update, params: {
          id: post.id,
          author: other_post.author,
          place: other_post.place,
          description: other_post.description,
          hashtags: other_post.hashtags,
          image: other_file
        }
      end

      it 'should have http status :ok' do
        expect(response).to have_http_status(:ok)
      end

      it 'should have different fields' do
        post_json = JSON.parse(response.body)
        expect(post_json['author']).not_to eq(post.author)
        expect(post_json).not_to eq(post.place)
        expect(post_json['description']).not_to eq(post.description)
        expect(post_json['hashtags']).not_to eq(post.hashtags)
      end

      it 'should not have the same image' do
        post_image_name = post.image_url.split('/').last
        body_image_name = JSON.parse(response.body)['image'].split('/').last
        expect(body_image_name).not_to eq(post_image_name)
      end

      it "should not increment the count by 1" do
        new_post = build(:post)

        initial_post_description = third_post.description
        expect{
          put :update, params: {
            id: third_post.id,
            author: new_post.author,
            place: new_post.place,
            description: new_post.description,
            hashtags: new_post.hashtags,
            image: other_file
          }
        }.to change { third_post.reload.description }.from(initial_post_description).to(new_post.description)
      end
    end

    context 'when post wasn\'t updated' do
      context 'when post wasn\'t found' do
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

      context 'when author has already been taken' do
        let(:post) { create :post, :with_image }
        let(:other_post) { create :post }
        let(:third_post) { build :post, { author: post.author } }

        before do
          put :update, params: {
            id: other_post.id,
            author: third_post.author,
            place: third_post.place,
            description: third_post.description,
            hashtags: third_post.hashtags,
            image: other_file
          }
        end

        it 'should have http status :unprocessable_entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should has errors: author => has already been taken' do
          author_errors = JSON.parse(response.body)['errors']['author']
          expect(author_errors).to include('has already been taken')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:post) { create :post, :with_image }
    context 'when post exists' do
      before do
        delete :destroy, params: { id: post.id }
      end

      it 'should have http status :no_content' do
        expect(response).to have_http_status(:no_content)
      end

      it 'should not find the post' do
        expect(Post.find_by_id(post.id)).to be_nil
      end
    end

    context 'when post does not exist' do
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

  describe '#Post with #Comments' do
    let(:post) { create :post, :with_image, :with_comments }

    context 'when post have comments' do
      it 'should have comments' do
        expect(post.comments.count).to be(5)
      end
    end
  end
end

