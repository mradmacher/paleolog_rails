class Menu
  attr_accessor :title, :items

   def initialize
    @items = []
  end
 
  def self.create( title, &block )
    menu = Menu.new
    menu.title = title
    yield menu if block_given?
    menu
  end

  def add( header, title, link, link_args = {} )
    item = MenuItem.new
		item.header = header
    item.title = title
    item.link = link
    item.link_args = link_args
    @items << item
  end

  def add_menu( title, &block )
    menu = Menu.new
    menu.title = title
    @items << menu
    yield menu if block_given?
  end

  def add( title, link, link_args = {} )
    item = MenuItem.new
    item.title = title
    item.link = link
    item.link_args = link_args
    @items << item
  end
end

class MenuItem
  attr_accessor :header, :title, :link, :link_args
end

