class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :prepare_meta_tags, if: "request.get?"
  after_action :prepare_unobtrusive_flash
  after_action :store_location

  before_action do
    if browser.device.mobile?
      request.variant = :mobile
    end
  end

  if Rails.env.production? or Rails.env.staging?
    rescue_from ActiveRecord::RecordNotFound, ActionController::UnknownFormat do |exception|
      render_404
    end
    rescue_from CanCan::AccessDenied do |exceptigson|
      self.response_body = nil
      if user_signed_in?
        redirect_to root_url, :alert => exception.message
      else
        redirect_to new_user_session_url, alert: '먼저 로그인 해주세요.'
      end
    end
    rescue_from ActionController::InvalidCrossOriginRequest, ActionController::InvalidAuthenticityToken do |exception|
      self.response_body = nil
      redirect_to root_url, :alert => I18n.t('errors.messages.invalid_auth_token')
    end
  end

  def store_location
    return unless request.get?
    if params[:redirect_to].present?
      store_location_for(:user, params[:redirect_to])
    elsif (!request.fullpath.match("/users") && !request.xhr?)
      store_location_for(:user, request.fullpath)
    end
  end

  def render_404
    self.response_body = nil
    render file: "#{Rails.root}/public/404.html", layout: false, status: 404
  end

  def errors_to_flash(model)
    flash[:error] = model.errors.full_messages.join('<br>').html_safe
  end

  def prepare_meta_tags(options={})
    set_meta_tags build_meta_options(options)
  end

  def build_meta_options(options)
    site_name = "우리가 주인이당! Would You Party?"
    title = options[:title] || "직접 민주주의 플랫폼, 우주당"
    image = options[:image] || view_context.image_url('seo.png')
    url = options[:url] || root_url
    description = options[:description] || "직접 민주주의 플랫폼, 우주당 '우리가 주인이당!'입니다"

    {
      title:       title,
      reverse:     true,
      image:       image,
      description: description,
      keywords:    "시민, 정치, 국회, 입법, 법안, 민주주의, 온라인정치, 정치참여, 우리가 주인이당, 정치개혁, Would You Party",
      canonical:   url,
      twitter: {
        site_name: site_name,
        site: '@parti_xyz',
        card: 'summary',
        title: title,
        description: description,
        image: image
      },
      og: {
        url: url,
        site_name: site_name,
        title: title,
        image: image,
        description: description,
        type: 'website'
      }
    }
  end

  #bugfix redactor2-rails
  def redactor_current_user
    redactor2_current_user
  end
end
