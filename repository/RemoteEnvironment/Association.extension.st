Extension { #name : #Association }

{ #category : #'*RemoteEnvironment' }
Association >> cpEncodeWith: anEncoder [

	<clientEnvironment>

	(#(#Association #ClassVariable #GlobalVariable #UndeclaredVariable #LiteralVariable) includes: self class name)
		ifFalse: [
			"Unsupported Association type"
			self halt ].

	anEncoder encodeAssociation: self
]
