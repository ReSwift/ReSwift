//
//  ActionCreator.swift
//  ReSwift
//
//  Created by Malcolm Jarvis on 2017-03-28.
//  Copyright © 2017 Benjamin Encz. All rights reserved.
//

import Foundation

/**
 An ActionCreator is a function that, based on the received state argument, might or might not
 create an action.

 Example:

 ```
 func deleteNote(noteID: Int) -> ActionCreator<AppState> {
    return { state in
        // only delete note if editing is enabled
        if (state.editingEnabled == true) {
            return NoteDataAction.DeleteNote(noteID)
        } else {
            return nil
        }
    }
 }
 ```

 */
public typealias ActionCreator<S: StateType> = (_ state: S) -> Action?
