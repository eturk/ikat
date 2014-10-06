class Category
  include Mongoid::Document
  include Mongoid::Tree
  include Rails.application.routes.url_helpers

  field :name,  type: String
  field :color, type: String
  field :slug,  type: String

  validates :name, presence: true

  before_validation :create_slug!

  has_many :products

  def self.as_options
    options = []

    self.roots.each do |root|
      root.descendants_and_self.each do |leaf|
        str = ''

        leaf.ancestors_and_self.each do |ancestor|
          str << "#{ancestor.name} > "
        end

        idx = leaf.id.to_s
        str = str[0..-4]

        options << [idx, str]
      end
    end

    def from_explore(arr)
      cats = []

      arr.each do |c|

        # This is the parent
        if cats.empty?
          cats << Category.where(slug: c).first

        # This is a child
        else
          parent = cats.last
          cats << parent.children.where(slug: c).first
        end
      end

      cats
    end
  end

  protected

  def create_slug!
    if self.name
      str = self.name

      str = str.gsub(/[^a-zA-Z0-9 ]/,"")
      str = str.gsub(/[ ]+/," ")
      str = str.gsub(/ /,"-")
      str = str.downcase

      self.slug = str
    end
  end
end
