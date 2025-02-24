# frozen_string_literal: true

module RequestSpecHelper
  def json_response
    @json_response ||= JSON.parse(response.body)
  end
end
