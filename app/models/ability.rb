class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.has_role? :admin
      can :manage, :all
    end

    if user.id
      # TODO: Should all logged in users be able to view editorial pages?
      can :view, :editorial_page
      can :manage, Node do |node|
        node.state == :draft && user.has_role?(:author, node.section)
      end

      can :update, Request do |request|
        request.state == 'requested' &&
            user.has_role?(:owner, request.section) &&
            user != request.user
      end

      can :read, Node do |node|
        node.state == :draft && user.has_role?(:reviewer, node.section)
      end
      can :create_in, Section do |section|
        user.has_role?(:author, section)
      end
    end

    # Everyone (signed in or not) can view published pages.
    can :read, Node, :state => :published
  end
end
