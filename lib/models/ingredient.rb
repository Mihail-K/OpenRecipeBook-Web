# frozen_string_literal: true

module Models
  class Ingredient < BaseModel
    include Features::Identifier

    attribute :name, Types::StrippedString
    attribute :products, Types::Array.of(Product).default([].freeze)

    # @return [Ingredient]
    def self.empty
      new(name:     '',
          products: [Product.empty])
    end

    # @return [String]
    def reference
      "ingredient:#{id}"
    end

    # @return [String]
    def generate_identifier
      super(name)
    end

    # @return [Hash]
    def serializable_hash
      { 'name'     => name,
        'products' => products.map(&:serializable_hash) }
        .compact
    end
  end
end
