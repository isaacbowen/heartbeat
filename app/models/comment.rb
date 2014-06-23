class Comment
  include ActiveModel::Model

  attr_accessor :source

  def body
    source.comments
  end

  def user
    source.user
  end

  def public?
    source.comments_public
  end

end
