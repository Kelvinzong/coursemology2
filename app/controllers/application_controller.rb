# frozen_string_literal: true
# :nodoc:
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by providing a null session when the token is missing from the request.
  protect_from_forgery(prepend: true, with: :exception)

  # Custom flash types. We follow Bootstrap's convention.
  add_flash_types :success, :info, :warning, :danger

  # We allow views to add breadcrumbs
  helper_method :add_breadcrumb

  include ApplicationMultitenancyConcern
  include ApplicationComponentsConcern
  include ApplicationInternationalizationConcern
  include ApplicationThemingConcern
  include ApplicationUserConcern
  include ApplicationUserTimeZoneConcern
  include ApplicationInstanceUserConcern
  include ApplicationAnnouncementsConcern
  include ApplicationPaginationConcern

  rescue_from IllegalStateError, with: :handle_illegal_state_error

  protected

  # Runs the provided block with Bullet disabled.
  #
  # @note Bullet will not be enabled again after this block returns until the next Rack request.
  #   The block syntax is in anticipation of Bullet eventually supporting temporary disabling,
  #   which currently does not work. See flyerhzm/bullet#247.
  def without_bullet
    old_bullet_enable = Bullet.enable?
    Bullet.enable = false
    yield
  ensure
    Bullet.enable = old_bullet_enable
  end

  # Redirects the browser to the page that issued the request (the referrer)
  # if possible, otherwise redirects to the provided default fallback
  # location.
  #
  # TODO: Remove this when upgrade to rails 5.
  def redirect_back(fallback_location:, **args)
    referer = request.headers['Referer']
    if referer
      redirect_to referer, **args
    else
      redirect_to fallback_location, **args
    end
  end

  private

  # Handles +IllegalStateError+s with a HTTP 422.
  def handle_illegal_state_error(exception)
    @exception = exception
    render file: 'public/422', layout: false, status: 422
  end
end
