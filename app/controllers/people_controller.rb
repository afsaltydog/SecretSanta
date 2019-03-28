class PeopleController < ApplicationController
  before_action :set_person, only: [:show, :edit, :update, :destroy]

  def wish
    if session[:person_id] != nil
      @wishlists = Person.find(session[:person_id]).wish_list
      puts "@wishlist is "+@wishlists.to_s
    else
      @wishlists = Person.find(params[:id]).wish_list
    end
    if @wishlists == nil
      redirect_to people_path
    else
      if session[:id].present?
        params[:id] = session[:person_id]
      else
        if params[:id].present?
          session[:person_id] = params[:id]
        end
      end
      render '/people/wishes'
    end
  end

  # GET /people
  # GET /people.json
  def index
    @people = Person.all
    puts "Session[:user_id] is "+session[:user_id].to_s
    person = Person.find_by name: session[:user_name]
    
    if person.present?
      puts "person is "+person.to_s
      puts "the person ID is "+person.id.to_s
      @wishlists = Person.find(person.id).wish_list.pluck(:item)
      @wishlists.to_s
      puts "This is @wishlist: "+@wishlists.to_s
      @people = Person.where(group_id: person.group_id)
    end
  end

  # GET /people/1
  # GET /people/1.json
  def show
    # @wishlists = Wishlist.joins(:person).where(:people => { :id => 1 }) # gets the whole row
    puts "Person name: "+session[:user_name]
    puts "params = "+params[:id]
    @person = Person.find_by name: session[:user_name]
    if @person == nil
      @person = Person.find_by id: params[:id]
    end
    if @person.present?
      @wishlists = Person.find(@person.id).wish_list.pluck(:item)
      @wishlists.to_s
      puts "This is @wishlist: "+@wishlists.to_s
    else
      # get person list by param id...
      # @people = Person.find_by group_id: session[:group_id]
      redirect_to people_path
    end
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
    if @person == nil
      @person = Person.find_by id: params[:id]
    end
    if @person == nil
      redirect_to people_path
    end
  end

  # POST /people
  # POST /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html { redirect_to @person, notice: 'Person was successfully created.' }
        format.json { render :show, status: :created, location: @person }
      else
        format.html { render :new }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1
  # PATCH/PUT /people/1.json
  def update
    respond_to do |format|
      if @person == nil
        @person = Person.find_by id: params[:id] 
      end
      if @person.update(person_params)
        format.html { redirect_to @person, notice: 'Person was successfully updated.' }
        format.json { render :show, status: :ok, location: @person }
      else
        format.html { render :edit }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.json
  def destroy
    if @person == nil
      @person = Person.find_by id: params[:id]
    end
    @person.destroy
    respond_to do |format|
      format.html { redirect_to people_url, notice: 'Person was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find_by name: session[:user_name]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def person_params
      params.require(:person).permit(:name, :spouse, :last_yr, :last_2yr, :current, :group_id)
    end
end
