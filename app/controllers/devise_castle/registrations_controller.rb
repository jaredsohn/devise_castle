class DeviseCastle::RegistrationsController < Devise::RegistrationsController
  unloadable unless Rails.version =~/^4/

  def create
    super do |resource|
      begin
        if resource.persisted?
          castle.track(
            name: '$registration.succeeded',
            user_id: resource._castle_id)
        else
          castle.track(
            name: '$registration.failed')
        end
      rescue ::Castle::Error => e
        if Devise.castle_error_handler.is_a?(Proc)
          Devise.castle_error_handler.call(e)
        end
      end
    end
  end

  def update_resource(resource, params)
    resource_updated = super

    begin
      if params['password'].present?
        if resource_updated
          castle.track(
            name: '$password_change.succeeded',
            user_id: resource._castle_id)
        else
          castle.track(
            name: '$password_change.failed',
            user_id: resource._castle_id)
        end
      end
    rescue ::Castle::Error => e
      if Devise.castle_error_handler.is_a?(Proc)
        Devise.castle_error_handler.call(e)
      end
    end

    resource_updated
  end
end
