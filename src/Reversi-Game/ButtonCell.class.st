Class {
	#name : #ButtonCell,
	#superclass : #SimpleButtonMorph,
	#instVars : [
		'row',
		'col',
		'pieceColor',
		'controller'
	],
	#category : #'Reversi-Game'
}

{ #category : #accessing }
ButtonCell >> board: aBoard [
	controller := aBoard
]

{ #category : #drawing }
ButtonCell >> drawOn: aCanvas [
	aCanvas
		frameAndFillRectangle: self bounds
		fillColor: Color brown
		borderWidth: 1
		borderColor: Color black.
	aCanvas fillOval: self bounds color: color
]

{ #category : #initialization }
ButtonCell >> initialize [
	super initialize.
	self borderWidth: 1.
	self label: ''.
	self extent: 50 @ 50.
	color := Color transparent.
	pieceColor := Color black.
	self on: #mouseDown send: #value to: self onClickExecutionBlock.
	^ self
]

{ #category : #action }
ButtonCell >> onClickExecutionBlock [
	^ [ 
	controller userClickRow: row col: col ]
]

{ #category : #accessing }
ButtonCell >> pieceColor: aColor [
	self color: aColor
]

{ #category : #accessing }
ButtonCell >> row: aRow col: aCol [
	row := aRow.
	col := aCol
]
