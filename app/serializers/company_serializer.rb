class CompanySerializer
  def initialize(company)
    @company = company
  end

  def as_json
    {
      id:                      @company.id,
      name:                    @company.name,
      business_name:           @company.business_name,
      slug:                    @company.slug,
      cif:                     @company.cif,
      ccc:                     @company.ccc,
      logo_url:                @company.logo_url,
      city:                    @company.city,
      province:                @company.province,
      postal_code:             @company.postal_code,
      street:                  @company.street,
      number:                  @company.number,
      floor:                   @company.floor,
      door:                    @company.door,
      contact_email:           @company.contact_email,
      contact_phone_main:      @company.contact_phone_main,
      contact_phone_secondary: @company.contact_phone_secondary,
      active:                  @company.active
    }
  end

  # Serialize a collection without loading each record into memory individually.
  # Usage: CompanySerializer.collection(@companies)
  def self.collection(companies)
    companies.map { |company| new(company).as_json }
  end
end
