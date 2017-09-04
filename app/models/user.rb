class User < ApplicationRecord
  before_save { self.email.downcase! }
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                    uniqueness: { case_sensitive: false }
  has_secure_password

# 1対多
  has_many :microposts
# 多対多 自分がフォローしている User 達取得
  has_many :relationships
  has_many :followings, through: :relationships, source: :follow
# 多対多 自分をフォローしている User 達取得
  has_many :reverses_of_relationship, class_name: 'Relationship', foreign_key: 'follow_id'
  has_many :followers, through: :reverses_of_relationship, source: :user

# 多対多 自分がお気に入りにしている microposts達取得
  has_many :favorites
  has_many :comments, through: :favorites, source: :micropost

# フォロー／アンフォロー／既フォロー調査
  def follow(other_user)
    unless self == other_user
      self.relationships.find_or_create_by(follow_id: other_user.id)
    end
  end

  def unfollow(other_user)
    relationship = self.relationships.find_by(follow_id: other_user.id)
    relationship.destroy if relationship
  end

  def following?(other_user)
    self.followings.include?(other_user)
  end

# お気に入り加入／お気に入り削除／既お気に入り調査
  def favcom(micropost)
      self.favorites.find_or_create_by(micropost_id: micropost.id)
  end

  def unfavcom(micropost)
    favorite = self.favorites.find_by(micropost_id: micropost.id)
    favorite.destroy if favorite
  end

  def favcoming?(micropost)
    self.comments.include?(micropost)
  end

  def feed_microposts
    Micropost.where(user_id: self.following_ids + [self.id])
  end
end
