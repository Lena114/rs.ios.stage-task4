import Foundation

final class CallStation {
    var usersList: [User] = []
    var callsList: [Call] = []
    var currentCalls: [Call] = []
}

extension CallStation: Station {
    func users() -> [User] {
        return self.usersList
    }
    
    func add(user: User) {
        if !self.usersList.contains(user) {
            self.usersList.append(user)
        }
    }
    
    func remove(user: User) {
        if let index = self.usersList.firstIndex(of: user) {
            self.usersList.remove(at: index)
        }
    }
    
    func execute(action: CallAction) -> CallID? {
        switch action {
        case let .start(from, to):
            var call: Call! = nil
            
            if !self.usersList.contains(from) && !self.usersList.contains(to) {
                return nil
            } else if !self.usersList.contains(from) || !self.usersList.contains(to) {
                call = Call(id: UUID(), incomingUser: to, outgoingUser: from, status: .ended(reason: .error))
            } else if self.currentCalls.contains(where: {$0.incomingUser == from || $0.incomingUser == to || $0.outgoingUser == from || $0.outgoingUser == to}) {
                call = Call(id: UUID(), incomingUser: to, outgoingUser: from, status: .ended(reason: .userBusy))
            } else {
                call = Call(id: UUID(), incomingUser: to, outgoingUser: from, status: .calling)
                self.currentCalls.append(call)
            }

            self.callsList.append(call)
            return call.id
            
        case let .answer(from):
            for call in self.currentCalls {
                if call.incomingUser == from {
                    var newCall: Call! = nil
                    
                    newCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .talk)
                    
                    if let index = self.currentCalls.firstIndex(where: {$0.id == call.id}) {
                        if !self.users().contains(call.incomingUser) || !self.users().contains(call.outgoingUser) {
                            self.currentCalls.remove(at: index)
                        } else {
                            self.currentCalls[index] = newCall
                        }
                    }
                    if let index = self.callsList.firstIndex(where: {$0.id == call.id}) {
                        if !self.users().contains(call.incomingUser) || !self.users().contains(call.outgoingUser) {
                            newCall = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: .error))
                            self.callsList[index] = newCall
                            return nil
                        } else {
                            self.callsList[index] = newCall
                            return newCall.id
                        }
                    }
                }
            }
            return nil
        case let .end(from):
            if let call = self.currentCall(user: from) {
                var newReason: CallEndReason! = nil
                
                if call.status == .calling {
                    newReason = .cancel
                } else {
                    newReason = .end
                }
                
                let newCall: Call = Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: .ended(reason: newReason))
                
                if let index = self.currentCalls.firstIndex(where: {$0.id == call.id}) {
                    self.currentCalls.remove(at: index)
                }
                if let index = self.callsList.firstIndex(where: {$0.id == call.id}) {
                    self.callsList[index] = newCall
                }
                return newCall.id
            }
        }
        return nil
    }
    
    func calls() -> [Call] {
        return self.callsList
    }
    
    func calls(user: User) -> [Call] {
        var result: [Call] = []
        for call in self.callsList {
            if call.incomingUser == user || call.outgoingUser == user {
                result.append(call)
            }
        }
        return result
    }
    
    func call(id: CallID) -> Call? {
        for call in self.callsList {
            if call.id == id {
                return call
            }
        }
        return nil
    }
    
    func currentCall(user: User) -> Call? {
        for call in self.currentCalls {
            if call.incomingUser == user || call.outgoingUser == user {
                return call
            }
        }
        return nil
    }
}
