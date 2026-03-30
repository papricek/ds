class Group < ApplicationRecord
  belongs_to :account

  has_many :group_customers, dependent: :destroy
  has_many :group_supplier_allocations, through: :group_customers

  validates :name, presence: true

  def unique_sharing_pairs
    pairs = []
    group_customers.includes(:group_supplier_allocations).each do |gc|
      gc.group_supplier_allocations.each do |gsa|
        pairs << { customer_ean: gc.ean, supplier_ean: gsa.ean }
      end
    end
    pairs.uniq
  end

  def customers_count
    group_customers.count
  end

  def suppliers_count
    group_supplier_allocations.distinct.count(:ean)
  end
end
