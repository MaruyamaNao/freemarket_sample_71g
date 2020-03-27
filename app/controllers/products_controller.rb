class ProductsController < ApplicationController

  before_action :set_product, only: [:edit, :show,:destroy,:edit,:update]

  def index
    
    @product_new = Product.where(buyer_id: nil).order("created_at DESC").limit(3)
    @product_random = Product.where(buyer_id: nil).order("RAND()").limit(3)
  end

  def new
    @product = Product.new
    @product.images.new
    @category_parent_array = ["---"]
    Category.where(ancestry: nil).each do |parent|
      @category_parent_array << parent.name
    end
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to products_path
    else
      redirect_to new_product_path, notice: '空の値があります'
    end
  end

  def show
  end

  def edit

    grandchild_category = @product.category
    child_category = grandchild_category.parent

    @category_parent_array = Category.where(ancestry: nil).pluck(:name)

    @category_children_array = Category.where(ancestry: child_category.ancestry)

    @category_grandchildren_array = Category.where(ancestry: grandchild_category.ancestry)

  end

  def update
    if @product.update(update_params)
      redirect_to root_path, notice: '更新にに成功しました。'
    else
      render :edit, alert: '更新に失敗しました。'
    end
  end

  def destroy
    if @product.destroy
      redirect_to root_path, notice: '消去に成功しました。'
    else
      render :show, alert: '消去に失敗しました。'
    end
  end

  def get_category_children
    @category_children = Category.find_by(name: "#{params[:parent_name]}", ancestry: nil).children
 end

 def get_category_grandchildren
    @category_grandchildren = Category.find("#{params[:child_id]}").children
 end

  private
  def product_params 
    params.require(:product).permit(:status, :name, :explanation, :price, :place, :shipping_date,:brand,:category_id,images_attributes: [:image]).merge(saler_id: current_user.id)
  end

  def update_params
    params.require(:product).permit(:status, :name, :explanation, :price, :place, :shipping_date,:brand,:category_id,images_attributes: [:image,:id,:_destroy]).merge(saler_id: current_user.id)
  end

  def set_product
    @product = Product.find(params[:id])
  end
end