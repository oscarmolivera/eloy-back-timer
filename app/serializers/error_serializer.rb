class ErrorSerializer
  def initialize(message:, status:, details: nil)
    @message = message
    @status  = status
    @details = details
  end

  def as_json
    payload = {
      error:   http_status_text,
      message: @message,
      status:  @status
    }
    payload[:details] = @details if @details.present?
    payload
  end

  # Convenience for validation errors (422)
  # Usage: ErrorSerializer.validation(@company.errors)
  def self.validation(errors)
    new(
      message: "Validation failed",
      status:  422,
      details: errors.to_hash
    ).as_json
  end

  private

  def http_status_text
    Rack::Utils::HTTP_STATUS_CODES[@status] || "Error"
  end
end
