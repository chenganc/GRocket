class Course < ActiveRecord::Base
  belongs_to :department
  has_many :associated_class, dependent: :destroy
  validates :number, length: {minimum: 1}
  validates :department_id, presence: true
end
