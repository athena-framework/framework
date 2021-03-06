# Represents a controller action argument. Stores metadata associated with it, such as its name, type, and default value if any.
struct Athena::Framework::Arguments::ArgumentMetadata(T)
  # Returns the name of the argument.
  getter name : String

  # Returns `true` if this argument has a default value set, otherwise `false`.
  getter? has_default : Bool

  protected def initialize(@name : String, @has_default : Bool = false, @default_value : T? = nil); end

  # If `nil` is a valid argument for the argument.
  def nilable? : Bool
    {{T.nilable?}}
  end

  # Returns the default value for this argument, raising an exception if it does not have one.
  def default_value : T
    raise "Argument '#{@name}' does not have a default value." unless self.has_default?

    @default_value.not_nil!
  end

  # Returns the default value for this argument, or `nil` if it does not have one.
  def default_value? : T?
    @default_value
  end

  # The type of the parameter, i.e. what its type restriction is.
  def type : T.class
    T
  end

  # Returns `true` if this argument's `#type` includes the provided *klass*.
  #
  # ```
  # ATH::Arguments::ArgumentMetadata(Int32).new("foo").instance_of?(Int32)       # => true
  # ATH::Arguments::ArgumentMetadata(Int32 | Bool).new("foo").instance_of?(Bool) # => true
  # ATH::Arguments::ArgumentMetadata(Int32).new("foo").instance_of?(String)      # => false
  # ```
  def instance_of?(klass : Type.class) : Bool forall Type
    {{ T.union? ? T.union_types.any? { |t| t <= Type } : T <= Type }}
  end

  # Returns the metaclass of the first matching type variable that is an `#instance_of?` the provided *klass*, or `nil` if none match.
  # If this the `#type` is union, this would be the first viable type.
  #
  # ```
  # ATH::Arguments::ArgumentMetadata(Int32).new("foo").first_type_of(Int32)                            # => Int32.class
  # ATH::Arguments::ArgumentMetadata(String | Int32 | Bool).new("foo").first_type_of(Int32)            # => Int32.class
  # ATH::Arguments::ArgumentMetadata(String | Int8 | Float64 | Int64).new("foo").first_type_of(Number) # => Float64.class
  # ATH::Arguments::ArgumentMetadata(String | Int32 | Bool).new("foo").first_type_of(Float64)          # => nil
  # ```
  def first_type_of(klass : Type.class) forall Type
    {% if T.union? %}
      {% for t in T.union_types %}
        {% if t <= Type %}
          return {{t}}
        {% end %}
      {% end %}
    {% elsif T <= Type %}
      {{T}}
    {% end %}
  end
end
