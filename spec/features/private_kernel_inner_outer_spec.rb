# frozen_string_literal: true

describe 'Symbiont: kernel context (kernel) => inner context (object) => outer context (proc)' do
  include_context 'private similar contexts'

  specify 'private KIO resolution' do
    closure = proc { object_data }

    result = private_symbiont_eval(object, direction: Symbiont::KIO, &closure)
    method = private_symbiont_method(:object_data, object, direction: Symbiont::KIO, &closure)
    expect(result).to      eq('kernel_data')
    expect(method.call).to eq('kernel_data')

    ::Kernel.send(:undef_method, :object_data)
    result = private_symbiont_eval(object, direction: Symbiont::KIO, &closure)
    method = private_symbiont_method(:object_data, object, direction: Symbiont::KIO, &closure)
    expect(result).to      eq('inner_data')
    expect(method.call).to eq('inner_data')

    object_class.send(:undef_method, :object_data)
    result = private_symbiont_eval(object, direction: Symbiont::KIO, &closure)
    method = private_symbiont_method(:object_data, object, direction: Symbiont::KIO, &closure)
    expect(result).to      eq('outer_data')
    expect(method.call).to eq('outer_data')

    undef object_data
    expect do
      private_symbiont_eval(object, direction: Symbiont::KIO, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)

    expect do
      private_symbiont_method(:object_data, object, direction: Symbiont::KIO, &closure)
    end.to raise_error(Symbiont::Trigger::ContextNoMethodError)
  end
end
