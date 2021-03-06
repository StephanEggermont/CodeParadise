Class {
	#name : #CpCheckbox,
	#superclass : #CpView,
	#instVars : [
		'state',
		'label'
	],
	#category : #'WebApplication-Components'
}

{ #category : #accessing }
CpCheckbox class >> cpRequiredClasses [

	^ super cpRequiredClasses, { CpSelectionChanged }
]

{ #category : #accessing }
CpCheckbox class >> label: labelElement [

	"Answer a new instance of the receiver with the specified label.
	Label can be a String in which case it is wrapped inside a <span> tag."

	^ self new
		label: labelElement ;
		yourself
]

{ #category : #'instance creation' }
CpCheckbox class >> new [

	"Answer new instance of the receiver.
	Register interest in this instance for event handling."

	| instance |

	instance := super new.
	CpBrowserEventHandler current registerInterestIn: instance.
	^ instance
]

{ #category : #'web resources' }
CpCheckbox class >> style [

	<webResource: #css>

	^ ':host {
			display: inline-flex;
			position: relative;
			white-space: nowrap;
			font-size: .8rem;
		}

		#container {
			display: inline-flex;
			width: 100%;
			height: 100%;
			min-height: inherit;
			align-items: center;
			justify-content: center;
			cursor: pointer;
		}

		#box {
			display: inline-block;
			position: relative;
			top: .125rem;
			width: .8rem;
			height: .8rem;
			margin-bottom: .25rem;
			margin-right: .25rem;
			border-radius: .25rem;
			border: 1px solid #333;
			overflow: hidden;
		}

		#tick {
			position: absolute;
			left: -50%;
			top: -50%;
			right: -50%;
			bottom: -50%;
			background-color: var(--control-activated-background-color);
			transform: rotate(0) translate(0,100%);
			transition: transform .5s;
		}

		:host([selected=""]) #tick {
			transform: rotate(0) translate(0,0);
		}
		
		:host([selected="mixed"]) #tick {
			transform: rotate(-45deg) translate(0,50%);
		}
		
		#label {
			flex: none;
		}'
]

{ #category : #'web resources' }
CpCheckbox class >> template [

	<webResource: #html>

	^ '<div id="container">
			<div id="box">
				<div id="tick"></div>
			</div>
			<div id="label">
				<slot name="label"></slot>
			</div>
		</div>'
]

{ #category : #'state handling' }
CpCheckbox >> deselect [

	"Remove the selected attribute of the receiver"

	self removeAttributeAt: #selected.
	state := false
]

{ #category : #'event handling' }
CpCheckbox >> handleClickEvent: anEvent [

	"Announce the new state of the receiver"

	self toggle.
	self announce: (CpSelectionChanged element: self)
]

{ #category : #accessing }
CpCheckbox >> label [

	"Answer label of receiver. If no label is set yet, check if label was set from a HTML string."

	^ label ifNil: [ label := self childAtSlotNamed: #label ]
]

{ #category : #accessing }
CpCheckbox >> label: anElement [

	"Set the specified element as the label of the receiver"

	label := self replaceChild: anElement asElement atSlotNamed: #label
]

{ #category : #'state handling' }
CpCheckbox >> mixed [

	"Set #mixed as value of the selected attribute of the receiver"

	self attributeAt: #selected put: #mixed.
	state := #mixed
]

{ #category : #'state handling' }
CpCheckbox >> select [

	"Add the selected attribute to the receiver"

	self attributeAt: #selected put: #''.
	state := true
]

{ #category : #accessing }
CpCheckbox >> state [

	^ state ifNil: [ state := (self attributeAt: #selected) notNil ]
]

{ #category : #'state handling' }
CpCheckbox >> toggle [

	"Toggle the state of the receiver.
	Implementation: state can be true, false or #mixed."

	self state = true
		ifTrue: [ self deselect ]
		ifFalse: [ self select ]
]
