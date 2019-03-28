class GroupsController < ApplicationController
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groupArray = Array.new
    groupHash = Hash.new
    @groups = Group.all
    @groups.each do |group|
      puts "group is"
      p group
      puts "group id is "+group.id.to_s
      count = Person.where(:group_id => group.id).count

      groupHash = {name: group.name, max_amt: group.max_amt, user: group.user, count: count, group: group}
      @groupArray.push(groupHash)
      puts "count is "+count.to_s
      p count
    end
    puts "groupArray.length is "+@groupArray.length.to_s
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
    # @people = Person.where(["group_id = :id", { id: session[:group_id] }])
    @people = Person.where(group_id: params[:id]).includes(:group)
    puts "@people is "+@people.to_s
    @people.each do |person|
      puts "person is "+person.name
    end
    @group_id = params[:id]
  end

  def randomizer
    puts "!!!!!!!!!!We are in Randomizer!!!!!!!!!!"
    puts "params[:id] is "+params[:id].to_s
    h = Hash.new
    doneArray = Array.new
    peopleArray = Array.new
    people = Person.where(group_id: params[:id])
    people.each do |person|
      puts "This person has id "+person.id.to_s
      can_have = Array.new
      can_have = Person.find_by_sql(["SELECT * FROM people WHERE name <> ? AND name <> ? AND name <> ? AND name <> ? AND group_id = ?", person.name, person.spouse, person.last_yr, person.last_2yr, person.group_id ])

      puts "person.name: "+person.name
      puts "can_have list has:"
      for y in 0..can_have.length-1
        testPerson = can_have[y]
        puts testPerson.name
      end
      h = {name: person.name, id: person.id, current: "", can_have: can_have, is_processed: false, popped_person: nil}
      # h[:name] = can_have
      # options = { font_size: 10, font_family: "Arial" }
      peopleArray.push(h)
    end

    # get a hash of anyone who has the same people in their can-have list
    process_first = get_same_list(peopleArray)
    puts "Process_first.length is "+process_first.length.to_s

    # h = {name: person.name, id: person.id, current: "", can_have: can_have, is_processed: false, popped_person: person}
    for i in 0..process_first.length-1
      # unpack the hash from the array
      personHash = process_first[i]
      # pass the hash to get_current
      personHash = get_current(personHash)
      puts "personHash from get_current is"
      p personHash
      puts "we just got done with get_current"
      popped_person = personHash[:popped_person]
      puts "popped_person is"
      p popped_person
      doneArray.push(personHash)
      # remove the popped person from all of the hashes in the peopleArray
      peopleArray = remove_from_array(peopleArray, personHash)
    end
    
    # go thru the persons with the smallest arrays 
    puts "go thru the persons with the smallest arrays"
    puts "with peopleArray:"
    p peopleArray
    process_first = get_smallest_array(peopleArray)
    # then process the rest
    puts "then process the rest"
    if process_first.length > 0
      for i in 0..process_first.length-1
        # unpack the hash from the array
        peopleHash = process_first[i]
        if !peopleHash[:is_processed]
          # pass the hash to get_current
          personHash = get_current(peopleHash)
          # popped_person = personHash[:popped_person]
          doneArray.push(personHash)
          # remove the popped person from all of the hashes in the peopleArray
          peopleArray = remove_from_array(peopleArray, personHash)
        end
      end
    end

    puts "Randomizing is finished!"
    @group = Group.find(params[:id])
    redirect_to @group
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)

    respond_to do |format|
      if @group.save
        format.html { redirect_to @group, notice: 'Group was successfully created.' }
        format.json { render :show, status: :created, location: @group }
      else
        format.html { render :new }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /groups/1
  # PATCH/PUT /groups/1.json
  def update
    respond_to do |format|
      if @group.update(group_params)
        format.html { redirect_to @group, notice: 'Group was successfully updated.' }
        format.json { render :show, status: :ok, location: @group }
      else
        format.html { render :edit }
        format.json { render json: @group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: 'Group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :max_amt, :user_id)
    end

    def get_current(personHash)
      # h = {name: person.name, id: person.id, current: "", can_have: can_have, is_processed: false}
      puts "-----get_current-----"
      puts "personHash[:is_processed] is "+personHash[:is_processed].to_s

      if !personHash[:is_processed]
        persons_can_have = Array.new
        # get the array of people from the hash that we can assign to their current person
        persons_can_have = personHash[:can_have]
        
        # shuffle the array of people
        if persons_can_have.length > 1
          persons_can_have.shuffle
        end

        # pop off the last person from the array
        popped_person = persons_can_have.pop
        puts "popped_person..."
        p popped_person

        name = personHash[:name]
        id = personHash[:id]

        if popped_person != nil
          puts "popped person's name is not nil and in fact, is: "
          p popped_person.name
          Person.find(id).update(:current => popped_person.name)
          # h = {name: person.name, id: person.id, current: "", can_have: can_have, is_processed: false, popped_person: person}
          personHash = {name: name, id: id, current: popped_person.name, :can_have => persons_can_have, :is_processed => true, :popped_person => popped_person}
        end
      end
                 
      return personHash
    end

    def get_same_list(peopleArray)
      # h = {name: person.name, id: person.id, current: "", can_have: can_have}
      puts "get_same_list"
      arr1 = Array.new
      arr2 = Array.new
      process_first = Array.new
      for i in 0..peopleArray.length - 2
        hash1 = peopleArray[i]
        arr1 = hash1[:can_have]
        for j in i..peopleArray.length - 1
          if i == j
            j += 1
          end
          hash2 = peopleArray[j]
          arr2 = hash2[:can_have]
          if arr1 != nil and arr2 != nil
            if they_are_equal(arr1, arr2)
              puts "They are equal! "+hash1[:name].to_s+" = "+hash2[:name].to_s
              if process_first.index(hash1) == nil
                process_first.push(hash1)
              end
              if process_first.index(hash2) == nil
                process_first.push(hash2)
              end
            end
          end  
        end
      end
      return process_first
    end

    def get_smallest_array(personArray)
      # h = {name: person.name, id: person.id, current: "", can_have: can_have, is_processed: false, popped_person: person}
      min = 0
      max = 0
      puts "~~~~~get_smallest_array~~~~~"
      puts "personArray.length is "+personArray.length.to_s
      length = personArray.length
      personHash = personArray[0]
      min = personHash[:can_have].length
      puts "min = "+min.to_s
      for i in 1..personArray.length-1
        personHash = personArray[i]
        arr = personHash[:can_have]
        if arr == nil
          # load all persons with no current person and set the min length
          if arr.length > 0
            if arr.length < min
              min = arr.length
            end
            if arr.length > max
              max = arr.length
            end
          end
        end
      end
      # go thru again pulling out those with the longest arrays and putting them at the back
      counter = 0
      puts "min = "+min.to_s
      puts "max = "+max.to_s
      while !is_sorted(personArray)
        personArray = fix_array(min, max, personArray)
        counter += 1
        if counter > 2
          puts "counter is 3...getting out of this crummy routine..."
          break
        end
      end
      return personArray
    end

    def fix_array(min, max, personArray)
    #   For I = 1 to N-1
    #    J = I
    #    Do while (J > 0) and (A(J) < A(J - 1)
    #      Temp = A(J)
    #      A(J) = A(J - 1)
    #      A(J - 1) = Temp
    #      J = J - 1 
    #    End-Do
    #  End-For
      length = personArray.length
      remoArray = []
      for i in 1..length-1
        j = i
        personHash = personArray[j]
        jl = personHash.length
        personHash = personArray[j-1]
        j1l = personHash.length
        while (j > 0) and (jl < j1l)
          temp = personArray[j]
          personArray[j] = personArray[j-1]
          personArray[j-1] = temp
          j = j-1
          personHash = personArray[j]
          if personHash != nil
            jl = personHash.length
          else
            jl = 0
          end
          personHash = personArray[j-1]
          if personHash != nil
            j1l = personHash.length
          else
            j1l = 0
          end
        end
      end
      puts ""
      puts ""
      puts "here is the attempt at fixing the array.."
      puts ""
      for x in 0..personArray.length-1
        p personArray[x]
        puts ""
      end
      puts ""
      puts "the personArray.length is now: "+personArray.length.to_s
      return personArray
    end

    def they_are_equal(array1, array2)
      isEqual = true
      puts "checking if the arrays are equal"
      puts "array1.length: "+array1.length.to_s
      puts "array2.length: "+array2.length.to_s
      if array1.length != array2.length
        isEqual = false
      else
        array1.sort!
        array2.sort!
        i = 0
        for i in 0..array1.length-1
          puts "array1[i].name = "+array1[i].name
          puts "array2[i].name = "+array2[i].name
          if array1[i].name != array2[i].name
            isEqual = false
            break
          end
        end
      end
      puts "return "+isEqual.to_s
      return isEqual
    end

    def remove_from_array(peopleArray, personHash)
      popped_person = personHash[:popped_person]
      if popped_person == nil
        puts "Arrgh! dump personHash"
        p personHash
      end
      puts "!!!!!!!!We are in remove_from_array with popped_person: "
      p popped_person
      puts "for person:"
      p personHash
      puts "peopleArray.length is "+peopleArray.length.to_s
      
      for x in 0..peopleArray.length-1
        puts "peopleArray is "
        p peopleArray[x]
        puts ""
        # unpack the hash
        puts "x is "+x.to_s
        peopleHash = peopleArray[x]
        puts "peopleHash is"
        p peopleHash
        puts "peopleHash[:id] = "+peopleHash[:id].to_s
        puts "personHash[:id] = "+personHash[:id].to_s
        if peopleHash[:id] == personHash[:id]
          puts "_______________________________________"
          
          puts "peopleHash[:id] == personHash[:id] so we clear the can_have list"
          personHash[:can_have] = []
          peopleArray[x] = personHash
        else
          # get the array from the hash
          can_have_list = peopleHash[:can_have]
          # remove the popped person from the array, if in the array

          pIndex = can_have_list.index(popped_person)
          puts "pIndex is "+pIndex.to_s
          if pIndex != nil
            can_have_list.slice!(pIndex)
            # put the array back in the hash
            peopleHash[:can_have] = can_have_list
            # put the hash back in the main array
            peopleArray[x] = peopleHash
          end
        end
      end
      return peopleArray
    end

    def is_sorted(personArray)
      isValid = true

      min = 0
      prev = 0
      personHash = personArray[0]
      min = personHash[:can_have].length
      for i in 1..personArray.length - 1
        personHash = personArray[i]
        puts "The bloody "+i.to_s+" personHash is"
        p personHash
        if personHash != nil
          if personHash[:can_have].length < min
            isValid = false
          end
          if prev == 0
            prev = personHash[:can_have].length
          else
            if personHash[:can_have].length < prev
              isValid = false
            end
          end
        end
      end

      return isValid
    end
end
