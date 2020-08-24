Class {
	#name : #CpCarouselSlideView,
	#superclass : #CpView,
	#category : #'CodeParadise-WebApplication-Presentation-View'
}

{ #category : #'web resources' }
CpCarouselSlideView class >> style [

	<webResource: #css>

	^ '* {
			box-sizing: border-box;
		}
		:host {
			position: absolute;
			width: 950px;
			height: 600px;
			left: 50px;
			top: 50px;
			border: 3px solid black;
			font-size: .75em;
			transition: transform 1s, opacity 1s;
		}
		.container {
			width: 100%;
			height: 100%;
			overflow: hidden;
			background-color: rgba(30, 30, 30, .2);
		}'
]

{ #category : #'web resources' }
CpCarouselSlideView class >> template [

	<webResource: #html>

	^ '<div class="container">
			<slot></slot>
		</div>'
]