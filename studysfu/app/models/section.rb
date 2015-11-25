class Section < ActiveRecord::Base
  belongs_to :associated_class
  has_many :section_times, dependent: :destroy
  has_many :exams, dependent: :destroy
  has_many :instructors, dependent: :destroy

  validates :unique_number, length: {minimum: 1}
  validates :key, length: {minimum: 1}
  validates :code, length: {minimum: 1}
  validates :associated_class_id, presence: true
end
