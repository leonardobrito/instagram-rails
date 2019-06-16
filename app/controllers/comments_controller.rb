class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :destroy]

  def index
    render json: Comment.all, each_serializer: CommentSerializer
  end

  def show
    render json: @comment, serializer: CommentSerializer
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      render json: @comment, status: :created, location: @comment, serializer: CommentSerializer
    else
      render_unprocessable_entity(@comment)
    end
  end

  def update
    if @comment.update(comment_params)
      render json: @comment, serializer: CommentSerializer
    else
      render_unprocessable_entity(@comment)
    end
  end

  def destroy
    @comment.destroy
  end

  private
    def set_comment
      @comment = Comment.find_by_id(params[:id])
      if @comment
        return @comment
      end
      render json: { error: "comment not found" }, status: :not_found
    end

    def render_unprocessable_entity(comment)
      render json: { errors: comment.errors }, status: :unprocessable_entity
    end

    def comment_params
      params.permit(:content, :post_id)
    end
end
