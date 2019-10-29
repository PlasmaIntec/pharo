"
A GameTest is a test class for testing the behavior of Game
"
Class {
	#name : #GameTest,
	#superclass : #TestCase,
	#category : #'Reversi-Game-Tests'
}

{ #category : #'as yet unclassified' }
GameTest >> testBoardGeneration [
	| b |
	b := Game new.
	self assert: [ ^ b board isNotEmpty ]
]

{ #category : #tests }
GameTest >> testCanCaptureCorrectly [
	| b |
	b := Game new.
	b placeAtRow: 6 col: 4.
	self assert: [ (b row: 6 col: 4) = $W ].
	self assert: [ (b row: 5 col: 4) = $W ].
	self assert: [ b turn = $B ].
	
]

{ #category : #tests }
GameTest >> testCanPlaceAt [
	| b |
	b := Game new.
	self assert: [ b canPlaceAtRow: 6 col: 4 ].
	self assert: [ (b canPlaceAtRow: 6 col: 3) not ].
]

{ #category : #tests }
GameTest >> testHasAllySupportAt [
	| b |
	b := Game new.
	self assert: [ ^ b hasAllySupportingAtRow: 3 col: 3 ].
	self assert: [ ^ b hasAllySupportingAtRow: 4 col: 3 ].
	self assert: [ ^ b hasAllySupportingAtRow: 5 col: 3 ].
	self assert: [ ^ (b hasAllySupportingAtRow: 6 col: 3) not ].
	self assert: [ ^ b hasAllySupportingAtRow: 7 col: 3 ].
	self assert: [ ^ (b hasAllySupportingAtRow: 8 col: 3) not ].
	
]

{ #category : #'as yet unclassified' }
GameTest >> testHasNeighboringEnemyAt [
	| b |
	b := Game new.
	self assert: [ ^ b hasNeighboringEnemyAtRow: 3 col: 4 ].
	self assert: [ ^ (b hasNeighboringEnemyAtRow: 3 col: 3) not ]
	
]
