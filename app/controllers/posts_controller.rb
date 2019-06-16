class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  def index
    render json: Post.all, each_serializer: PostSerializer
  end

  def show
    render json: @post, serializer: PostSerializer
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      render json: @post, status: :created, location: @post, serializer: PostSerializer
    else
      render_unprocessable_entity(@post)
    end
  end

  def update
    if @post.update(post_params)
      render json: @post, serializer: PostSerializer
    else
      render_unprocessable_entity(@post)
    end
  end

  def destroy
    @post.destroy
  end

  private
    def set_post
      @post = Post.find_by_id(params[:id])
      if @post
        return @post
      end
      render json: { error: "post not found" }, status: :not_found
    end

    def render_unprocessable_entity(post)
      render json: { errors: post.errors }, status: :unprocessable_entity
    end

    def post_params
      params.permit(:author, :place, :description, :hashtags, :image, :likes)
    end
end
