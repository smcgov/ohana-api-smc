module PrivateRegistration
  def create
    build_resource(sign_up_params)

    if resource.save
      process_successful_registration
    elsif resource_valid_except_for_duplicate_email?
      process_private_registration
    else
      remove_has_already_been_taken_error
      process_unsuccessful_registration
    end
  end

  private

  def resource_valid_except_for_duplicate_email?
    resource_class.find_by(email: resource.email).present? &&
      only_email_error_is_duplicate?
  end

  def only_email_error_is_duplicate?
    resource.errors.attribute_names == [:email] &&
      resource.errors.messages_for(:email).uniq == ['has already been taken']
  end

  def process_private_registration
    AdminMailer.existing_email_signup(resource).deliver_now
    if is_flashing_format?
      set_flash_message :notice, :signed_up_but_unconfirmed, email: resource.email
    end
    redirect_to after_registration_url_for(resource)
  end

  def after_registration_url_for(resource)
    return new_admin_session_url if resource.is_a?(Admin)

    new_user_session_url if resource.is_a?(User)
  end

  def process_successful_registration
    set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
    expire_data_after_sign_in!
    redirect_to after_registration_url_for(resource)
  end

  def process_unsuccessful_registration
    clean_up_passwords resource
    @validatable = devise_mapping.validatable?
    @minimum_password_length = resource_class.password_length.min if @validatable
    render :new
  end

  def remove_has_already_been_taken_error
    previous_email_errors = resource.errors.messages_for(:email)
    resource.errors.delete(:email)
    previous_email_errors.each do |message|
      next if message == 'has already been taken'

      resource.errors.add(:email, message)
    end
  end
end
