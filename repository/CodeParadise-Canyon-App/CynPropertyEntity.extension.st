Extension { #name : #CynPropertyEntity }

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> addVolume: aVolume locale: aSymbol [

	self languageText
		addVolume: aVolume locale: aSymbol
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> count: anInteger text: aSymbolOrTextReference [

	^ self count: anInteger text: aSymbolOrTextReference format: nil
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> count: anInteger text: aSymbolOrTextReference format: aDictionary [

	^ self languageText
		count: anInteger key: aSymbolOrTextReference format: aDictionary
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> deleteAllUri [

	"Answer the URI where the receiver is located for performing a 'delete all' operation"

	^ self uri, ':deleteAll'
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> index: anInteger text: aSymbolOrTextReference [

	^ self index: anInteger text: aSymbolOrTextReference format: nil
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> index: anInteger text: aSymbolOrTextReference format: aDictionary [

	^ self languageText
		index: anInteger key: aSymbolOrTextReference format: aDictionary
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> languageText [

	^ self configAt: #languageText ifAbsent: [ self error: 'No languageText is set by default, please fix this' ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> languageText: aLanguageText [

	self configAt: #languageText put: aLanguageText
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restApiClient [

	"Use the REST API Client stored in my configuration"

	^ self configAt: #restApiClient
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restApiClient [

	"Answer the REST API Client which allows loading/storing of the receiver.
	By default the class is responsible to know this."

	^ self class restApiClient
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restApiClient: aRestApiClient [

	"Store the specified REST API Client in my configuration"

	self configAt: #restApiClient put: aRestApiClient
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restBodyContent [

	"Answer the receiver as body content (String) for a REST request"

	^ CpJavaScriptJSON stringify: self asJsonObjectValue
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restBodyForDeleteAll: aCollection [

	| first |

	first := true.
	^ String streamContents: [ :stream |
		stream nextPut: $[.
		aCollection do: [ :each |
			each class = self
				ifFalse: [ self error: ('Deleting elements: element has incompatible type {1}, expecting {2}' format: { each class name . self name }) ].
			first
				ifTrue: [ first := false ]
				ifFalse: [ stream nextPut: $, ].
			stream
				nextPut: $" ;
				nextPutAll: each id ;	"Ids don't contain double quotes, no escaping needed"
				nextPut: $" ].
		stream nextPut: $] ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restCreateTimeoutPeriod [

	"Answer the create timeout period in milliseconds"

	^ self restApiClient
		requestTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restCreateUsingUri: aString timeoutPeriod: anInteger [

	"Create the resource using the specified URI"

	(self restApiClient postUri: aString body: self restBodyContent timeoutPeriod: anInteger)
		ifNotNil: [ :content | self merge: content ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restDelete [

	"Delete the resource"

	"If the resource is new, delete is a no-op"
	self isNew
		ifTrue: [
			self announce: (CynModelDeleted model: self).
			^ self ].

	self
		restDeleteUsingUri: self uri
		timeoutPeriod: self restDeleteTimeoutPeriod.

	self announce: (CynModelDeleted model: self)
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restDeleteAll: aCollection [

	"Delete (all) the resources (assumed same 'type' as receiver) in the specified Collection.
	This operation will fail if the resources are not instances of the receiver.
	This method does not answer any specific value. On failure an Error will be signalled."

	self
		restDeleteAll: aCollection
		usingUri: self deleteAllUri
		timeoutPeriod: self restDeleteAllTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restDeleteAll: aCollection usingUri: aString timeoutPeriod: anInteger [

	"Delete all the resources in the specified Collection (assuming all have the receiver's 'type')
	using the specified URI.
	This method does not answer any specific value. On failure an Error will be signalled."

	self restApiClient
		postUri: aString
		body: (self restBodyForDeleteAll: aCollection)
		timeoutPeriod: anInteger
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restDeleteAllTimeoutPeriod [

	"Answer the delete all timeout period in milliseconds"

	^ self restApiClient
		requestTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restDeleteTimeoutPeriod [

	"Answer the delete timeout period in milliseconds"

	^ self restApiClient
		requestTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restDeleteUsingUri: aString timeoutPeriod: anInteger [

	"Delete the resource using the specified URI"

	(self restApiClient deleteUri: aString timeoutPeriod: anInteger)
		ifNotNil: [ :content | self merge: content ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restRead [

	"Read (all) the resources of the receiver's 'type'"

	^ self
		restReadUsingUri: self uri
		timeoutPeriod: self restReadTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restRead [

	"Read the resource using its identity"

	"Signal error if receiver does not have an identity"
	self isNew
		ifTrue: [ self error: 'Can''t load a resource without an identity' ].

	self
		restReadUsingUri: self uri
		timeoutPeriod: self restReadTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restReadTimeoutPeriod [

	"Answer the read timeout period in milliseconds"

	^ self restApiClient
		requestTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restReadTimeoutPeriod [

	"Answer the read timeout period in milliseconds"

	^ self restApiClient
		requestTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restReadUsingUri: aString queryParams: aDictionary timeoutPeriod: anInteger [

	"Read (all) the resources of the receiver's 'type' using the specified URI and query parameters.

	If the session has expired this will answer an empty collection."

	^ (self restApiClient getUri: aString queryParams: aDictionary timeoutPeriod: anInteger)
		ifNotNil: [ :array | array collect: [ :each | self fromDictionary: each ] ]
		ifNil: [ #() ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restReadUsingUri: aString timeoutPeriod: anInteger [

	"Read (all) the resources of the receiver's 'type' using the specified URI.

	If the session has expired this will answer an empty collection."

	^ (self restApiClient getUri: aString timeoutPeriod: anInteger)
		ifNotNil: [ :array | array collect: [ :each | self fromDictionary: each ] ]
		ifNil: [ #() ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restReadUsingUri: aString timeoutPeriod: anInteger [

	"Read the resource using the specified URI"

	(self restApiClient getUri: aString timeoutPeriod: anInteger)
		ifNotNil: [ :content | self merge: content ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> restReadWithQueryParams: aDictionary [

	"Read (all) the resources of the receiver's 'type' using the specified query parameters"

	^ self
		restReadUsingUri: self uri
		queryParams: aDictionary
		timeoutPeriod: self restReadTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restUpdateTimeoutPeriod [

	"Answer the Update timeout period in milliseconds"

	^ self restApiClient
		requestTimeoutPeriod
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restUpdateUsingUri: aString timeoutPeriod: anInteger [

	"Update the resource using the specified URI"

	(self restApiClient putUri: aString body: self restBodyContent timeoutPeriod: anInteger)
		ifNotNil: [ :content | self merge: content ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> restWrite [

	"Store the resource"

	self isNew
		ifTrue: [
			self
				restCreateUsingUri: self uri
				timeoutPeriod: self restCreateTimeoutPeriod ]
		ifFalse: [
			self
				restUpdateUsingUri: self uri
				timeoutPeriod: self restUpdateTimeoutPeriod ]
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> text: aSymbolOrParamText [

	^ self text: aSymbolOrParamText format: nil
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> text: aSymbolOrTextReference format: aDictionary [

	^ self languageText
		key: aSymbolOrTextReference format: aDictionary
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity class >> uri [

	"Answer the URI where the receiver is located"

	^ self shouldBeImplemented
]

{ #category : #'*CodeParadise-Canyon-App' }
CynPropertyEntity >> uri [

	"Answer the URI where the receiver is located"

	^ self isNew
		ifTrue: [ self class uri ]
		ifFalse: [ '{1}/{2}' format: { self class uri . id } ]
]
