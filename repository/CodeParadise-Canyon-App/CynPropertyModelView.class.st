"
I am a PropertyModel View. I am responsible for setting up and tearing down
property bindings between the model and the view. This ensures that my model
and view stay in sync. I will validate the model when the user enters data
into the view. By default validation issues are shown at the appropriate
input field. Before 'committing' these changes I can also validate the model
and show a friendly message to the user about the validation results.
"
Class {
	#name : #CynPropertyModelView,
	#superclass : #CynModelView,
	#instVars : [
		'originalModel'
	],
	#category : #'CodeParadise-Canyon-App-View'
}

{ #category : #binding }
CynPropertyModelView >> addBindings [

	"Add any bindings between the model and the receiver"

	super addBindings.

	self addPropertyBindings
]

{ #category : #binding }
CynPropertyModelView >> addPropertyBindings [

	"Add any property bindings between the model and the receiver"

	self boundProperties do: [ :each |
		self bindProperty: each ]
]

{ #category : #binding }
CynPropertyModelView >> bindProperty: aSymbol [

	"Add bindings (2x for two-way) for the specified property.
	Assuming the element which the property is bound to has the
	same identifier as the property name.
	Otherwise use #bindProperty:toElement: directly"

	self bindProperty: aSymbol toElement: (self shadowedElementWithId: aSymbol)
]

{ #category : #binding }
CynPropertyModelView >> bindProperty: aSymbol toElement: anElement [

	"Bind the specified property of the receiver's model to an Element and vice versa (two-way binding).
	Also add binding to normalize the property after an input element has lost focus.
	Keep track of the bindings created, so clean-up can be performed afterwards."

	"Initialize the element"
	anElement initializeForModel: model property: aSymbol.

	"Set initial value based on receiver's model"
	anElement valueFromModel: (model propertyAt: aSymbol).

	"Add binding from model to element"
	self addBinding: (model
		when: (CynPropertyChanged name: aSymbol) do: [ :event | anElement valueFromModel: event newValue ] for: self).

	"Done when readonly element"
	anElement isReadonly
		ifTrue: [ ^ self ].

	"Add binding from element to model"
	self addBinding: (anElement
		whenChangedDo: [ model propertyAt: aSymbol put: anElement valueForModel ] for: self).

	"When an input element loses focus, perform normalization and validation"
	self addBinding: (anElement
		when: IonBlurEvent
		deferDo: [
			model normalizePropertyAt: aSymbol.
			self validateProperty: aSymbol ]
		for: self)
]

{ #category : #binding }
CynPropertyModelView >> boundProperties [

	"Answer a collection of property names (Symbols) for the receiver's model,
	which should be bound to the receiver's UI components"

	^ #()
]

{ #category : #operations }
CynPropertyModelView >> doDelete [

	"Delete the receiver's model and keep the result"

	super doDelete
		ifFalse: [ ^ false ].

	self keepResult.

	^ true
]

{ #category : #operations }
CynPropertyModelView >> doWrite [

	"Write the receiver's model and keep the result"

	super doWrite
		ifFalse: [ ^ false ].

	self keepResult.

	^ true
]

{ #category : #testing }
CynPropertyModelView >> isDirtyProperty: aSymbol [

	"Answer whether the specified property has changed"

	^ (originalModel propertyAt: aSymbol) ~= (model propertyAt: aSymbol)
]

{ #category : #testing }
CynPropertyModelView >> isModelDirty [

	"Answer whether the receiver's model has changed"

	^ originalModel ~= model
]

{ #category : #operations }
CynPropertyModelView >> keepResult [

	"Keep the receiver's result.

	Implementation:
	Merge the copied model into the original and set it as modal result"

	originalModel merge: model.

	self modalResult: originalModel
]

{ #category : #accessing }
CynPropertyModelView >> model: aModel [

	"Work with a copy of the specified Model.
	This allows to recognize changes and prevents updating the 'original'
	until done."

	originalModel := aModel.

	super model: (self workOnCopy
		ifTrue: [ aModel copy ]
		ifFalse: [ aModel ])
]

{ #category : #'validating - private' }
CynPropertyModelView >> modelViolations [

	"Answer a Collection of Strings representing the constraint violations in the properties of the model"

	| violations |

	violations := Dictionary new.

	"Add model violations"
	model modelViolationsDo: [ :violation |
		violations
			at: nil
			ifPresent: [ :collection | collection add: violation ]
			ifAbsentPut: [ OrderedCollection with: violation ] ].

	"Add property violations"
	self propertiesForValidation do: [ :each |
		model propertyViolationsAt: each do: [ :violation |
			violations
				at: each
				ifPresent: [ :collection | collection add: violation ]
				ifAbsentPut: [ OrderedCollection with: violation ] ] ].

	^ violations
]

{ #category : #validating }
CynPropertyModelView >> propertiesForValidation [

	"Answer the collection of properties which should be considered during validation of the receiver's model"

	^ self boundProperties
]

{ #category : #validating }
CynPropertyModelView >> validateModelIfValid: validBlock ifInvalid: invalidBlock [

	"Validate the receiver's Model and evaluate the appropriate Block.
	If the Model is invalid the invalidBlock will be evaluated (culled) with
	a Dictionary. The Dictionary will contain the property name (a Symbol)
	as key and a collection of violation keys (Symbol or CynTextReference)
	specifying the issues encountered for that partical property. If a nil
	key is present, it refers to a collection of violations on the Model which
	is not related to one specific property (like the Model's integrity
	violations).
	If the Model is valid the validBlock is evaluated without parameters.

	Both validBlock and/or invalidBlock can be nil, in which case no evaluation
	is performed for that particular situation. This means that if invalidBlock
	is nil and the receiver's Model is invalid, nothing will happen: there is
	no fallback mechanism in such case to indicate the Model is invalid."

	self modelViolations
		ifNotEmpty: [ :violations |
			invalidBlock ifNil: [ ^ self ].
			invalidBlock cull: violations ]
		ifEmpty: [
			validBlock ifNil: [ ^ self ].
			validBlock value ]
]

{ #category : #validating }
CynPropertyModelView >> validateProperty: aSymbol [

	"Validate the specified Property of the receiver's Model and
	update the input element to indicate the validity"

	| errorText |

	errorText := model errorTextForPropertyAt: aSymbol.

	(self shadowedElementWithId: aSymbol)
		errorText: errorText ;
		classed: #'ion-invalid' if: errorText isNotNil ;
		classed: #'ion-valid' if: errorText isNil ;
		classed: #'ion-touched' if: (self isDirtyProperty: aSymbol)
]

{ #category : #testing }
CynPropertyModelView >> workOnCopy [

	"Answer whether the receiver should work on a copy of the model.
	Most forms work on a copy, but some views might work on the model directly."

	^ true
]
