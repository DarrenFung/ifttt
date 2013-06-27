class PairingsMailer < ActionMailer::Base
  default from: 'IFTTT Apprentice <ifttt@ifttt.com>'

  def paired(pairing)
    @pairing = pairing
    mail(
      to: @pairing.user1.email,
      subject: "Your 1+1 Pairing for this week"
    )
  end

  def odd_pairing(user)
    @user = user
    mail to: user.email, subject: "Sorry, no 1+1 pairing this week!"
  end

end
