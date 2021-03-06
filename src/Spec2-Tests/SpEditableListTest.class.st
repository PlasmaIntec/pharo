Class {
	#name : #SpEditableListTest,
	#superclass : #SpSmokeTest,
	#category : #'Spec2-Tests-Core-Widgets'
}

{ #category : #running }
SpEditableListTest >> classToTest [
	^ SpEditableList
]

{ #category : #tests }
SpEditableListTest >> testMoveElementAtTo [
	presenter list: {'AAA' . 'BBB' . 'CCC'}.
	presenter moveElementAt: 1 to: 3.
	self
		assert: presenter list model items asArray 
		equals: {'BBB' . 'CCC' . 'AAA'}
]
