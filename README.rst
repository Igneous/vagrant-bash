vagrant-bash
============

:Installation on Linux:

  1) Git clone this repo into your homedir somewhere *(if you have a ~/scripts, or ~/include, that would be ideal)*.

  2) assuming we used ~/scripts, do: ``sudo ln -s ~/scripts/vagrant-bash/bash_completion.d/vagrant.inc.sh /etc/bash_completion.d/vagrant``

    - *I personally prefer to store this in ~/scripts/vagrant-bash because it's easier to hack on and reload.. but there's nothing preventing you from storing it in /usr/lib/vagrant-bash for instance. That would probably be a wiser choice on a truly multi-user system, anyway.*

  3) Restart your shell/terminal, or ``exec bash``



:Notes:

  vagrant-bash tries to provide a framework for interacting with vagrant in bash, expanding beyond the original goals of just tab-completion for vagrant, and instead focusing on providing some helper functions, which could be used to build a killer bash $PS1, run basic tests from a CI suite, or perhaps be used for writing vagrant-centric nagios checks.



:Why Bother?:

  I wanted a way to see which Vagrant VMs were running in my bash prompt.. so when I cd'd into a vagrant project directory, I would know the current state of my project. Unfortunately, 'vagrant status' took far too long to start up mri/jruby/rbx just to spit out a list of running vms, so before I could consider trying to parse its output, it was out of the question. Since my problem revolved around bash usability, I figured I'd attempt a solution in (as close to native as possible) bash.

  .. image:: http://i.imgur.com/j7k0C.png
      :align: center

:Credits:

  -  Originally forked from Kura's vagrant-bash-completion_.
  -  Uses dominictarr's JSON.sh_.

.. _vagrant-bash-completion: https://github.com/kura/vagrant-bash-completion
.. _JSON.sh: https://github.com/dominictarr/JSON.sh
