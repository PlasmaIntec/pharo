Extension { #name : #OSPlatform }

{ #category : #'*Native-Browser' }
OSPlatform >> openOSFileBrowserOn: aFileReference [
	"Opens an OS-specific file and directory browser on ==aFileReference==. If aFileReference is a file, opens the browser on its containing directory instead."

	| ref |
	(aFileReference isNil or: [ aFileReference exists not ]) ifTrue: [ ^ nil ].
	ref := aFileReference isFile
		ifTrue: [ aFileReference parent ]
		ifFalse: [ aFileReference ].
	(ref isNil or: [ ref exists not ]) ifTrue: [ ^ nil ].
	self privateOpenOSFileBrowserOn: ref pathString
]

{ #category : #'*Native-Browser' }
OSPlatform >> privateOpenOSFileBrowserOn: aPathString [
	"My subclasses should open a native browser on the path string without any check."
	
	^ self subclassResponsibility
]
