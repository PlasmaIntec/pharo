"
Unit test writing and reading of comments
"
Class {
	#name : #STONWriteReadCommentsTest,
	#superclass : #STONWriteReadTest,
	#category : #'STON-Tests-Writer'
}

{ #category : #private }
STONWriteReadCommentsTest >> materialize: string [
	^ STON reader
		on: (STONCStyleCommentsSkipStream on: string readStream);
		optimizeForLargeStructures;
		next
]

{ #category : #private }
STONWriteReadCommentsTest >> serialize: anObject [
	^ String streamContents: [ :stream |
		stream << '/* initial comment */'.
		STON writer 
			on: stream;
			nextPut: anObject.
		stream << '/* final comment */' ]
]
