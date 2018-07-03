import Foundation
import ReSwift

class MiddlewareExecutor<T:StateType>{
    func execute(action:Action, state:T?, nextDispatcher:@escaping DispatchFunction) -> Action?{
        return nil;
    }
}

class MiddlewaresCollection<T:StateType>{
    private var _middlewares:[Middleware<T>];
    init(){
        self._middlewares = [];
    }
    
    func concact(withCollection:MiddlewaresCollection)->MiddlewaresCollection{
        self._middlewares = _middlewares + withCollection.middlewares;
        return self;
    }
    
    func add(_ middlewareItens:MiddlewareExecutor<T>...)->MiddlewaresCollection{
        for item in middlewareItens {
            self._middlewares.append ({ (dispatch, state) -> (@escaping DispatchFunction) -> DispatchFunction in
                return { next in
                    return { action in
                        if let nextAction = item.execute(action: action, state: state(), nextDispatcher: next){
                            next(nextAction);
                        }
                    }
                }
            });
        }
    
        return self;
    }
    
    public var middlewares:[Middleware<T>]{
        return self._middlewares;
    }
}
