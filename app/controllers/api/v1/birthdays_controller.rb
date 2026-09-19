module Api
  module V1
    class BirthdaysController < Api::BaseController
      rate_limit to: 60, within: 1.minute, only: %i[create update],
        by: -> { current_api_token.id },
        with: -> { render json: { error: "rate_limited" }, status: :too_many_requests }

      def index
        birthdays = current_user.birthdays.order(:month, :day, :id).map(&:as_api)
        render json: { birthdays: birthdays }
      end

      def show
        birthday = current_user.birthdays.find_by(id: params[:id])
        return render_not_found unless birthday

        render json: { birthday: birthday.as_api }
      end

      def create
        birthday = current_user.birthdays.new(birthday_params)
        if birthday.save
          render json: { birthday: birthday.as_api }, status: :created
        else
          render_unprocessable(birthday)
        end
      end

      def update
        birthday = current_user.birthdays.find_by(id: params[:id])
        return render_not_found unless birthday

        if birthday.update(birthday_params)
          render json: { birthday: birthday.as_api }
        else
          render_unprocessable(birthday)
        end
      end

      def destroy
        birthday = current_user.birthdays.find_by(id: params[:id])
        return render_not_found unless birthday

        birthday.destroy
        head :no_content
      end

      private
        def birthday_params
          nested = params[:birthday]
          source = nested.is_a?(ActionController::Parameters) ? nested : params
          source.permit(:name, :month, :day, :year, :body)
        end
    end
  end
end
