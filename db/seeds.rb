# %x( rake import:criteria )

# hotel properties
group = Property::Group.where(:name => Alternative::HOTEL_ATTRIBUTES_GROUP_NAME).first_or_create!

address_field = Property::Field.where(:name => Alternative::STARS_PROPERTY_FIELD_SHORT_NAME.capitalize, 
                                      :short_name => Alternative::STARS_PROPERTY_FIELD_SHORT_NAME, 
                                      :field_type => 'integer', 
                                      :group_id => group.id).first_or_create!

