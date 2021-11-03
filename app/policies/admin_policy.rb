class AdminPolicy
  attr_reader :user, :admin

  def initialize(user, admin)
    @user = user
    @admin = admin
  end

  def update?
    user.super_admin?
  end

  alias edit? update?
end
