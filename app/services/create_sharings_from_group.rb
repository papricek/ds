require "simple_command"

class CreateSharingsFromGroup
  prepend SimpleCommand

  def initialize(group, default_price: nil)
    @group = group
    @default_price = default_price
  end

  def call
    created = []
    @group.unique_sharing_pairs.each do |pair|
      from_address = Address.find_by(ean: pair[:supplier_ean], account: @group.account)
      to_address = Address.find_by(ean: pair[:customer_ean], account: @group.account)
      next unless from_address && to_address

      sharing = Sharing.find_or_initialize_by(
        from_address: from_address,
        to_address: to_address,
        account: @group.account
      )

      if sharing.new_record?
        sharing.fixed_price = @default_price
        sharing.status = :active
        sharing.save!
        created << sharing
      end
    end
    created
  end
end
