class PrototypeObject

  def initialize(properties = {})
    @properties = properties
    @properties.each do |property_name, value|
      set_property(property_name, value)
    end
  end

  def set_property(property_name, value)
    @properties = @properties.merge(property_name => value) ## Piso los valores, genera un dict nuevo
    
    case value
    when Proc
      define_singleton_method(property_name, &value)
    else
      define_singleton_method(property_name) {get_property(property_name)} 
    end
  end

  def get_property(property_name)
    @properties.fetch(property_name) {raise PropertyNotFoundError.new}
  end

  def copy
    self.class.new(@properties)
  end
end

class PropertyNotFoundError < StandardError
end

describe 'Prototyped Objects' do
  it 'should set/get property' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    expect(guerrero.get_property(:energia)).to eq 100

  end

  it 'should raise error when property is undefined' do

    guerrero = PrototypeObject.new

    expect{guerrero.get_property(:energia)}.to raise_error(PropertyNotFoundError)

  end

  it 'should define methods for properties' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    expect(guerrero.energia).to eq 100
    expect(guerrero.respond_to?(:energia)).to be true

  end

  it 'should raise NoMethodError if property is not defined' do

    guerrero = PrototypeObject.new

    expect{ guerrero.energia }.to raise_error(NoMethodError)
    expect(guerrero.respond_to?(:energia)).to be false

  end

  it 'should call proc/lambda on set property' do
    guerrero = PrototypeObject.new
    guerrero.set_property(:saludar, proc {"Hola!"})

    expect(guerrero.saludar).to eq "Hola!"
  end

  it 'should access to object properties' do
    
    guerrero = PrototypeObject.new
    guerrero.set_property(:nombre, 'Pepe')
    guerrero.set_property(:saludar, -> { "Hola!, soy #{nombre}" })

    expect(guerrero.saludar).to eq "Hola!, soy Pepe"

  end

  it 'should access to object properties and pass arguments' do
  
    guerrero = PrototypeObject.new
    guerrero.set_property(:nombre, 'Pepe')
    guerrero.set_property(:saludar, proc { |a| "Hola #{a}!, soy #{nombre}" })

    expect(guerrero.saludar('José')).to eq "Hola José!, soy Pepe"
  
  end

  it 'should copy object with properties' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    otro_guerrero = guerrero.copy

    expect(otro_guerrero.energia).to eq 100

  end


  it 'should copy object with properties but they are different objects' do

    guerrero = PrototypeObject.new
    guerrero.set_property(:energia, 100)

    otro_guerrero = guerrero.copy
    otro_guerrero.set_property(:energia, 150)

    expect(guerrero.energia).to eq 100
    expect(otro_guerrero.energia).to eq 150

  end

end