module Admin
  class SessionsController < ApplicationController
    # Limit brute-force attempts per client IP; the backing store is configurable
    # through Rails.cache and works with the in-memory store used locally.
    rate_limit to: 5, within: 15.minutes, only: :create,
      with: -> { head :too_many_requests }

    def new
      redirect_to admin_articles_path if session[:admin_authenticated]
    end

    def create
      user, password = ENV.values_at("BLOG_ADMIN_USER", "BLOG_ADMIN_PASSWORD")
      if user.blank? || password.blank?
        flash.now[:alert] = "O acesso administrativo ainda não foi configurado no servidor."
        return render :new, status: :service_unavailable
      end

      provided_user = params[:username].to_s
      provided_password = params[:password].to_s
      if secure_match?(provided_user, user) && secure_match?(provided_password, password)
        destination = session[:return_to_admin]
        reset_session
        session[:admin_authenticated] = true
        redirect_to destination.presence || admin_articles_path, notice: "Login realizado com sucesso."
      else
        flash.now[:alert] = "Usuário ou senha incorretos."
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      reset_session
      redirect_to root_path, notice: "Você saiu da área privada."
    end

    private

    def secure_match?(provided, expected)
      ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(provided),
        Digest::SHA256.hexdigest(expected)
      )
    end
  end
end
