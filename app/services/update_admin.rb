class UpdateAdmin
  include ActiveModel::Model

  validate :admin_exists

  attr_reader :email

  def initialize(email)
    @email = email
    @success = false
  end

  def call
    @admin = Admin.find_by(email: email)

    if valid?
      @admin.update(super_admin: true)
      success = true
    end

    success
  end

  private

  attr_accessor :success

  def admin_exists
    if @admin.nil?
      return errors.add(
        :email,
        'This email is not yet registered. Please ask them to create an account.'
      )
    end

    admin_confirmed
  end

  def admin_confirmed
    return if @admin.confirmed?

    errors.add(
      :email,
      'This email is registered but not yet confirmed. Please ask them to ' \
      'click on the link in their confirmation email.'
    )
  end
end
