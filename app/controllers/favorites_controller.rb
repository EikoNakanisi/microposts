class FavoritesController < ApplicationController
  before_action :require_user_logged_in

  def index
    @user = current_user
    @favorites = Favorite.where(user_id: @user.id).all
  end


  def create
    micropost = Micropost.find(params[:micropost_id])
    current_user.favcom(micropost)
    flash[:success] = 'お気に入りにしました。'
    redirect_back(fallback_location:root_path)
  end

  def destroy
    micropost = Micropost.find(params[:micropost_id])
    current_user.unfavcom(micropost)
    flash[:success] = 'お気に入り削除しました。'
    redirect_back(fallback_location:root_path)
  end
end
