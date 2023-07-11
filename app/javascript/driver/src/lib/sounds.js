  import CancelSound from '../../public/sounds/cancel.mp3'
  import AcceptSound from '../../public/sounds/accept.mp3'
  import ProposalSound from '../../public/sounds/proposal.mp3'
  import DecidedSound from '../../public/sounds/decided.mp3'
  import UpdateSound from '../../public/sounds/update.mp3'
  import SosSound from '../../public/sounds/sos.mp3'

  export const sounds = {
    cancel: new Audio(CancelSound),
    accept: new Audio(AcceptSound),
    proposal: new Audio(ProposalSound),
    decline: new Audio(DecidedSound),
    update: new Audio(UpdateSound),
    sos: new Audio(SosSound)
  }

  export const vibrations = {
    cancel: [1000],
    accept: [200, 100, 200],
    proposal: [200, 100, 200],
    decline: [1000],
    update: [200, 100, 200],
    sos: [100,30,100,30,100,200,200,30,200,30,200,200,100,30,100,30,100]
  }
