class CompleteIndex < Chewy::Index

  define_type Criterion do
    field :name
  end

  define_type Property::Field, name: 'fields' do
    field :name
  end

end
